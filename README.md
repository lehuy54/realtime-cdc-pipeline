# Realtime CDC Pipeline | Data Engineering Project

## 📑 Mục lục
- [Giới thiệu](#-giới-thiệu)  
- [Kiến trúc hệ thống](#-kiến-trúc-hệ-thống)   
- [Hướng dẫn cài đặt & chạy](#️-hướng-dẫn-cài-đặt--chạy)  
- [Giao diện quản trị](#-giao-diện-quản-trị)  

---

## Giới thiệu

 Đồng bộ dữ liệu thường dựa vào trigger trong database nhưng xem ra cách này sẽ gây tải nặng lên hệ thống nguồn nếu dữ liệu đủ lớn, cộng hưởng với việc khó quản lí. Với Change Data Capture, kỹ thuật bắt sự thay đổi của dữ liệu từ log của database đảm bảo ít ảnh hưởng đến hiệu năng, đồng thời dữ liệu được truyền đi gần như thời gian thực đến các hệ thống downstream

---

## Kiến trúc hệ thống

![Kiến trúc hệ thống](https://github.com/lehuy54/realtime-cdc-pipeline/blob/main/System%20Architecture.png)

- **Data source**: MySQL, giả sử các dữ liệu realtime về transaction từ hệ thống OLTP đẩy vào  
- **Debezium (Source Connector)**: plugins của kafka connect đảm nhiệm CDC, đọc bin log của MySQL để bắt các action làm thay đổi dữ liệu như **insert, update, delete**, sau đó convert thành Avro format để publish change event lên topic Kafka
- **Kafka**: Message broker truyền dữ liệu. Sử dụng **KRaft mode** để tự quản lý metadata. Trong project này chỉ sử dụng 1 broker, 1 replication. Mỗi topic trong đây sẽ tương ứng với một table trong database. Tuy nhiên, do thằng Debezium đã convert nó thành Avro nên các message chỉ bao gồm schema ID (sẽ quyết định bên trong Schema Registry) + dữ liệu serialized
- **Schema Registry**: Dịch vụ trung gian của Kafka dùng để quản lý và lưu trữ schema cho dữ liệu trong topic, ở trường hợp này ta config nó đang nắm giữ Avro format. Nó giúp producer và consumer thống nhất dữ liệu, đảm bảo compability khi có schema thay đổi. Ngoài ra giúp ta tiết kiệm bộ nhớ hơn khi message được bắn đi không phải ở dạng Json  
- **Sink Connector**: Ta sử dụng trực tiếp plugin Google BigQuery Sink connector của Confluentinc cung cấp, để nó lấy dữ liệu từ Kafka topic, deserialize theo schema từ Schema Registry, sau đó load vào BigQuery dataset tương ứng
- **Google BigQuery**: cloud data warehouse, trong kịch bản này nó sẽ nhận hết dữ liệu deserialized từ thằng sink connector (vì thế nên nó sẽ bao gồm các cột before after của dữ liệu - nếu như đó là action update)

---

## Hướng dẫn cài đặt & chạy

1. Clone repository:
    ```bash
    git clone https://github.com/lehuy54/realtime-cdc-pipeline.git
    ```
2. Tải connectors cần thiết và giải nén vào thư mục `connectors/`

- **Source Connector (MySQL Debezium):**  
  [Tải tại đây](https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/2.5.4.Final/debezium-connector-mysql-2.5.4.Final-plugin.tar.gz)

- **Sink Connector (Google BigQuery):**  
  [Tải tại đây](https://www.confluent.io/hub/wepay/kafka-connect-bigquery)

*Lưu ý: Sử dụng bản **Self-managed** cho môi trường Docker/local.*


3. Tạo Service Account trên BigQuery, cấp quyền **BigQuery Admin** và quyền **BigQuery Data Editor**. Tạo Json key và tải về đặt trong root của src code và rename nó thành 'bigquery-credentials.json' 

4. ở GCP Console, vào BigQuery -> Create Dataset -> đặt dataset_id là "inventory_cdc"

5. Vào Cloud overview -> Dashboard -> để lấy Project ID sau đó thay thành project id của bạn trong file 'bigquery-connector.json':
    ```bash
    "project": "your-id-project"
    ```
6. Khởi động tất cả các service:
    ```bash
    docker compose up -d
    ```
7. cd về root src và đăng kí 2 connectors
    ```bash
    curl -X POST http://localhost:8083/connectors \
        -H "Content-Type: application/json" \
        -d @mysql-connector.json

    ```
    ```bash
    curl -X POST http://localhost:8083/connectors \
        -H "Content-Type: application/json" \
        -d @bigquery-connector.json

    ```
8. Có thể lên kafka-ui tại cổng `localhost:8080` để kiểm tra xem các topic đã được tạo chưa, 
   tên của các topic sẽ được đặt tên theo config của debezium connector: 
   `<topic.prefix>.<database>.<table>`

9. Kiểm tra dữ liệu trên Google BigQuery:
    ```bash
    SELECT * FROM `YOUR_PROJECT_ID.inventory_cdc.dbserver1_inventory_customers` LIMIT 10;
    ```
10. Có thể chạy scripts python data generator để mô phỏng kịch bản realtime:
    ```bash
    python -m venv venv

    ./venv/Scripts/activate

    pip install mysql-connector-python faker

    python streaming-data.py
    ```
