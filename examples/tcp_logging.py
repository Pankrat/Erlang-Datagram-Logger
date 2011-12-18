"""
Demonstrate logging from Python to the Erlang logging service via TCP sockets.

Requires a custom Python logging handler.
"""

from logging import getLogger, Formatter, DEBUG
from logging.handlers import SocketHandler
from time import sleep


class ErlangSocketHandler(SocketHandler):
    """
    Don't pickle log record before sending. Simply format it and send the
    string to the logging server. Otherwise the receiver would need to decode
    the pickled data and still do the formatting.
    """
    def makePickle(self, record):
        return self.format(record)


def set_up_logger(host="127.0.0.1", port=1057):
    logger = getLogger("erlang_logger")
    logger.setLevel(DEBUG)
    handler = ErlangSocketHandler(host, port)
    formatter = Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    return logger


def test_congestion(logger, iterations=10000):
    """Test logging at a high frequency - at some point messages will be dropped."""
    for i in range(iterations):
        logger.debug("Test fast sending of messages %d" % i)
        if i % 50 == 0:
            sleep(0.001)


def test_large_message(logger, length=9000):
    """This message will be truncated when received."""
    msg = "<" + ("." * (length-2)) + ">"
    logger.debug(msg)


logger = set_up_logger()
test_congestion(logger)
test_large_message(logger)
logger.info("That's it")
