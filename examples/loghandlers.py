"""
Don't pickle log record before sending. Simply format it and send the
string to the logging server. Otherwise the receiver would need to decode
the pickled data and still do the formatting.

Use the handlers like this:

    logger = getLogger("erlang_logger")
    logger.setLevel(DEBUG)
    handler = ErlangSocketHandler(host, port)
    formatter = Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    return logger

If you use a config file:

    [formatter_generic]
    format = %(asctime)s,%(msecs)03d %(levelname)-5.5s [%(name)s] %(message)s
    datefmt = %Y-%m-%d %H:%M:%S

    [handler_socket]
    class = loghandlers.ErlangDatagramHandler
    args = ("127.0.0.1", 1056)
    level = DEBUG
    formatter = generic
"""

from logging.handlers import DatagramHandler, SocketHandler


class ErlangSocketHandler(SocketHandler):
    def makePickle(self, record):
        # TODO: include message separator so receiver can reconstruct large
        # messages (bigger than receive buffer)
        return self.format(record)


class ErlangDatagramHandler(DatagramHandler):
    def makePickle(self, record):
        return self.format(record)
