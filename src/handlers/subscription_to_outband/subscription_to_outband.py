import json

from aws_lambda_powertools.utilities.data_classes import (
    LambdaFunctionUrlEvent,
    event_source,
)

from utils.logger import create_logger, logging_handler

logger = create_logger(__name__)


@event_source(data_class=LambdaFunctionUrlEvent)
@logging_handler(logger)
def handler(event, context):
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"msg": "hello"}, ensure_ascii=False),
    }
