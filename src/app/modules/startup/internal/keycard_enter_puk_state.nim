type
  KeycardEnterPukState* = ref object of State

proc newKeycardEnterPukState*(flowType: FlowType, backState: State): KeycardEnterPukState =
  result = KeycardEnterPukState()
  result.setup(flowType, StateType.KeycardEnterPuk, backState)

proc delete*(self: KeycardEnterPukState) =
  self.State.delete

method executePrimaryCommand*(self: KeycardEnterPukState, controller: Controller) =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if controller.getPuk().len == PUKLengthForStatusApp:
      controller.enterKeycardPuk(controller.getPuk())
  elif self.flowType == FlowType.AppLogin:
    if controller.getPuk().len == PUKLengthForStatusApp:
      controller.enterKeycardPuk(controller.getPuk())

method resolveKeycardNextState*(self: KeycardEnterPukState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if self.flowType == FlowType.FirstRunOldUserKeycardImport:
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorUnblocking:
        return createState(StateType.KeycardCreatePin, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUK:
        controller.setKeycardData($keycardEvent.pukRetries)
        if keycardEvent.pukRetries > 0:
          return createState(StateType.KeycardWrongPuk, self.flowType, self.getBackState)
        return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)
  if self.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueEnterNewPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorUnblocking:
        return createState(StateType.KeycardCreatePin, self.flowType, self.getBackState)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == RequestParamPUK:
        controller.setKeycardData($keycardEvent.pukRetries)
        if keycardEvent.pukRetries > 0:
          return createState(StateType.KeycardWrongPuk, self.flowType, self.getBackState)
        return createState(StateType.KeycardMaxPukRetriesReached, self.flowType, self.getBackState)