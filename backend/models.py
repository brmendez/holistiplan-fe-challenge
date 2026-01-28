from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash

db = SQLAlchemy()

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    is_active = db.Column(db.Boolean, default=True)
    is_admin = db.Column(db.Boolean, default=False)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'created_at': self.created_at.isoformat(),
            'is_active': self.is_active,
            'is_admin': self.is_admin
        }

class Server(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    hostname = db.Column(db.String(255), nullable=False)
    ip_address = db.Column(db.String(45), nullable=False)
    status = db.Column(db.String(20), default='online')  # online, offline, maintenance, error
    cpu_usage = db.Column(db.Float, default=0.0)
    memory_usage = db.Column(db.Float, default=0.0)
    disk_usage = db.Column(db.Float, default=0.0)
    uptime = db.Column(db.Integer, default=0)  # in seconds
    location = db.Column(db.String(100), default='Unknown')
    os = db.Column(db.String(50), default='Linux')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'hostname': self.hostname,
            'ip_address': self.ip_address,
            'status': self.status,
            'cpu_usage': self.cpu_usage,
            'memory_usage': self.memory_usage,
            'disk_usage': self.disk_usage,
            'uptime': self.uptime,
            'location': self.location,
            'os': self.os,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
