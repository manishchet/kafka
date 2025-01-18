from kafka import KafkaConsumer
import json

# Kafka configuration
bootstrap_servers = ["hostname1:6667", "hostname2:6667", "hostname3:6667"]
topic_name = "TEST"

consumer = KafkaConsumer(
    topic_name,
    bootstrap_servers=bootstrap_servers,
    security_protocol="SASL_SSL",
    sasl_mechanism="SCRAM-SHA-512",
    sasl_plain_username="manish2",
    sasl_plain_password="manish#123",
    ssl_cafile="/home/manishkumar2.c/new.pem",
    value_deserializer=lambda v: json.loads(v.decode("utf-8")),
    key_deserializer=lambda k: k.decode("utf-8") if k else None,
    auto_offset_reset="earliest",
    enable_auto_commit=True,
    group_id="consumer-group-1"
)

def consume_messages():
    try:
        print("Consuming messages...")
        for message in consumer:
            key = message.key
            value = message.value
            print(f"Key: {key}, Value: {value}")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        consumer.close()

if __name__ == '__main__':
    consume_messages()
