import json
from typing import Any, Dict


def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    API Gateway Lambda Proxy V2形式でeventの中身をJSON形式で返すダミー関数
    """
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(event, ensure_ascii=False, indent=2)
    }