import os
from dotenv import load_dotenv

from base.application import create_app

# Attach Debugger
'''
try:
  import googleclouddebugger
  googleclouddebugger.enable(
      breakpoint_enable_canary=True,
      service_account_json_file='env_config/client-secret.json')
except ImportError:
  pass
'''

ENV = os.environ.get('FLASK_ENV', 'development')
PORT = os.environ.get('PORT', 8080)

dotenv_file = '.env'
load_dotenv(dotenv_file)

# Initialize application
app = create_app()