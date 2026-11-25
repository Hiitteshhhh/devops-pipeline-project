from flask import Flask, jsonify
import platform, os, time

app = Flask(__name__)
START_TIME = time.time()

@app.route('/')
def index():
    return jsonify({
        'message': 'DevOps Pipeline API',
        'version': '1.0.0',
        'framework': 'Flask'
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'uptime_seconds': round(time.time() - START_TIME, 2)
    })

@app.route('/info')
def info():
    return jsonify({
        'hostname': os.environ.get('HOSTNAME', 'unknown'),
        'os': platform.system(),
        'python_version': platform.python_version(),
        'environment': os.environ.get('APP_ENV', 'development')
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
