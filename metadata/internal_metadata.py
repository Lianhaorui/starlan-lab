from flask import Flask, jsonify

app = Flask(__name__)

# 固定值,与 db/init.sql 中 IDOR/SQLI flag 同风格,便于教学核对
flag = "flag{a1f4c2d8e9b063715c4a8d2f0e6b9c3d}"

@app.get("/latest/meta-data/")
def root():
    return "instance-id\nlocal-ipv4\niam/security-credentials/club-platform\n"

@app.get("/latest/meta-data/instance-id")
def instance():
    return "i-0f3a9c2e1b8d4a67\n"

@app.get("/latest/meta-data/local-ipv4")
def local_ipv4():
    return flag + "\n"

@app.get("/latest/meta-data/iam/security-credentials/club-platform")
def credentials():
    return jsonify({
        "AccessKeyId": "ASIA3XW2P9QK5M8T1ZB4",
        "SecretAccessKey": flag,
        "Token": "e8f2a1b94c7d6053f2a1b94c7d6053f2a1b94c7d6053f2a1b94c7d6053f2a1"
    })

@app.get("/health")
def health():
    return jsonify(ok=True)

app.run(host="0.0.0.0", port=80)
