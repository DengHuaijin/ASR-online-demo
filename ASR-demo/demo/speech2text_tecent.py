import json
import base64
import re
from tencentcloud.common import credential
from tencentcloud.common.profile.client_profile import ClientProfile
from tencentcloud.common.profile.http_profile import HttpProfile
from tencentcloud.common.exception.tencent_cloud_sdk_exception import TencentCloudSDKException
from tencentcloud.asr.v20190614 import asr_client, models
try:
    cred = credential.Credential("AKIDd4JJ4dRFgutiJ0tz962nLityxhck7AC3", "sYFyWrV7VeYEUSBpofKm8A2jH6mERzTa")
    httpProfile = HttpProfile()
    httpProfile.endpoint = "asr.tencentcloudapi.com"

    clientProfile = ClientProfile()
    clientProfile.httpProfile = httpProfile
    client = asr_client.AsrClient(cred, "", clientProfile)

    f = open("static/upload/recordAudio.wav", "rb")
    speechdata = f.read()
    speechdata = base64.b64encode(speechdata).decode("utf-8")

    req = models.CreateRecTaskRequest()
    params = {
        "EngineModelType": "16k_en",
        "ChannelNum": 1,
        "ResTextFormat": 0,
        "SourceType": 1,
        "Data": speechdata
    }
    req.from_json_string(json.dumps(params))

    resp = client.CreateRecTask(req)
    print(resp.to_json_string())

    ### get result ###
    polling = True
    taskid = int(re.search(r'"TaskId": (.*)},', resp.to_json_string()).group(1))
    print(taskid)
    while polling:
        req = models.DescribeTaskStatusRequest()
        params = {
            "TaskId": taskid
        }
        req.from_json_string(json.dumps(params))
        resp = client.DescribeTaskStatus(req)
        status = int(re.search(r'"Status": (.),', resp.to_json_string()).group(1))
        if status == 2:
            polling = False
            response = resp.to_json_string()
            result = response.split("  ")[1].split(r"\n")[0]
            if "requestId" in result:
                result = "Recognition Failed"
        elif status == 3:
            polling = False
            result = "Recognition Failed"

    print(result)

except TencentCloudSDKException as err:
    print(err)
