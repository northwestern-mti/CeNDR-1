import os
import logging

from dotenv import load_dotenv
from pkg.caendr.models import DictSerializable

dotenv_file = '.env'
load_dotenv(dotenv_file)

download_path = ".download"

