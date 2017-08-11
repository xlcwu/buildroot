################################################################################
#
# python-s3cmd
#
################################################################################

PYTHON_S3CMD_VERSION = 2.0.0
PYTHON_S3CMD_SOURCE = s3cmd-$(PYTHON_S3CMD_VERSION).tar.gz
PYTHON_S3CMD_SITE = https://pypi.python.org/packages/f1/ca/dcec06e5ffeb6add7cc919cd952a5881b03ad6e43a9ecf158c0fce5c48ab
PYTHON_S3CMD_SETUP_TYPE = setuptools
PYTHON_S3CMD_LICENSE = GNU General Public License v2 or later (GPLv2+)

$(eval $(python-package))
