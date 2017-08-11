################################################################################
#
# python-magic
#
################################################################################

PYTHON_MAGIC_VERSION = 0.4.13
PYTHON_MAGIC_SOURCE = python-magic-$(PYTHON_MAGIC_VERSION).tar.gz
PYTHON_MAGIC_SITE = https://pypi.python.org/packages/65/0b/c6b31f686420420b5a16b24a722fe980724b28d76f65601c9bc324f08d02
PYTHON_MAGIC_SETUP_TYPE = setuptools
PYTHON_MAGIC_LICENSE = MIT
PYTHON_MAGIC_LICENSE_FILES = LICENSE

$(eval $(python-package))
