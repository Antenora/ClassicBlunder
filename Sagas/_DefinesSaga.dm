mob/proc/tierUpSaga(path)
    src << "Saga [path] is tiered up to [SagaLevel]!"

sagaTierUpMessages
    var/list/messages = list()

sagaInfo
    var/list/perLevelPassives = list()
    var/list/specificPassives = list()
    var/list/choicePassives = list()
    var/list/chosenChoices = list()
    var/list/skillsPerTier = list()
    var/list/choicesPaths = list()
    var/list/pathsPicked = list()

