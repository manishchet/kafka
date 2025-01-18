from kafka import KafkaProducer
import json
import random

# Kafka configuration
bootstrap_servers = ["hostanem1:6667", "hostanme2:6667", "hostanem3:6667"]
topic_name = "TEST1"

producer = KafkaProducer(
    bootstrap_servers=bootstrap_servers,
    security_protocol="SASL_SSL",
    sasl_mechanism="SCRAM-SHA-512",
    sasl_plain_username="manish",
    sasl_plain_password="manish#123",
    ssl_cafile="/home/manishkumar2.c/devtruststore_combined.pem",
    value_serializer=lambda v: json.dumps(v).encode("utf-8"),
    key_serializer=lambda k: k.encode("utf-8")
)

def generate_random_message():
    return {
        "id": random.randint(1, 1000),
        "name": ''.join(random.choices("abcdefghijklmnopqrstuvwxyz", k=5)),
        "age": random.randint(20, 50),
        "city": ''.join(random.choices("abcdefghijklmnopqrstuvwxyz ", k=7)).strip()
    }

def produce_messages():
    try:
        for _ in range(1000):
            message = generate_random_message()
            key = f"{message['id']}_{message['name']}"
            producer.send(topic_name, value=message, key=key)
        producer.flush()
        print("1000 messages sent successfully")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    produce_messages()
