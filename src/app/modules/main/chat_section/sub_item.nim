import strformat
import base_item

export base_item

type 
  SubItem* = ref object of BaseItem
    parentId: string

proc initSubItem*(id, parentId, name, icon: string, isIdenticon: bool, color, description: string, hasUnreadMessages: bool, 
  notificationsCount: int, muted, active: bool, position: int): SubItem =
  result = SubItem()
  result.setup(id, name, icon, isIdenticon, color, description, hasUnreadMessages, notificationsCount, muted, active, 
  position)
  result.parentId = parentId

proc delete*(self: SubItem) = 
  self.BaseItem.delete

proc parentId*(self: SubItem): string = 
  self.parentId

proc `$`*(self: SubItem): string =
  result = fmt"""ChatSectionSubItem(
    itemId: {self.id}, 
    parentItemId: {self.parentId}, 
    name: {self.name}, 
    icon: {self.icon},
    isIdenticon: {self.isIdenticon},
    color: {self.color}, 
    description: {self.description},
    hasUnreadMessages: {self.hasUnreadMessages}, 
    notificationsCount: {self.notificationsCount},
    muted: {self.muted},
    active: {self.active},
    position: {self.position},
    ]"""