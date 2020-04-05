import json
members = f = open("demofile.txt", "r")
membersTemplate = { members: [
      {
        _id: VARIABLE_IDOFPOD_VARIABLE,
        host: VARIABLE_HOSTNAMEOFPOD_VARIABLE,
        arbiterOnly: false,
        buildIndexes: true,
        hidden: false,
        priority: 0,
        tags: { "SERVICE_NAME": "VARIABLE_SERVICENAME_VARIABLE" },
        slaveDelay: 0,
        votes: 0
      },

    ]}

# parse x:
y = json.loads('./replicaset.conf')

# the result is a Python dictionary:
newReplicaSetConfig = json