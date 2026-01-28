import os
from datetime import timedelta

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'sqlite:///servers.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SESSION_TYPE = 'filesystem'
    SESSION_PERMANENT = False
    PERMANENT_SESSION_LIFETIME = timedelta(hours=24)
    SESSION_USE_SIGNER = True
    SESSION_KEY_PREFIX = 'server_dashboard:'
