@antenna = d3.dispatch 'graphChanged', 'nodeChanged', 'linkChanged',
  'readyForEntry',
  'createNode', 'finishNode', 'updateNodeText',
  'editNode', 'editNextNode', 'editPrevNode',
  'log'

