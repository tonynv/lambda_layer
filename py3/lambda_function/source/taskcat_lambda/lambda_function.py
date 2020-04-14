#!/usr/bin/env python

"""
taskat lambda stub
"""

from taskcat._cli import get_installed_version as taskcat_version


def lambda_handler(event, context):
    """
    Return taskcat version in layer
    """
    return taskcat_version()
