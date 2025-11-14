import { ContextMenu, ContextMenuTrigger, ContextMenuItem, ContextMenuContent } from "@/components/ui/context-menu"
import { HoverCard, HoverCardContent, HoverCardTrigger } from "@/components/ui/hover-card"
import { ItemMedia } from "@/components/ui/item"

import { Item } from "@/components/ui/item"

export const InventoryItem = () => {
    return (
        <ContextMenu>
            <ContextMenuTrigger>
                <HoverCard>
                    <HoverCardTrigger>
                        <div className="w-full h-30 bg-accent rounded">
                            <Item>
                                <ItemMedia>
                                    <img src="https://via.placeholder.com/150" alt="Item" className="w-full h-full object-cover" />
                                </ItemMedia>
                            </Item>
                        </div>
                    </HoverCardTrigger>
                    <HoverCardContent className="w-80 pointer-events-none select-none">
                        The React Framework – created and maintained by @vercel.
                    </HoverCardContent>
                </HoverCard>
                
            </ContextMenuTrigger>
            <ContextMenuContent>
                <ContextMenuItem>Profile</ContextMenuItem>
                <ContextMenuItem>Billing</ContextMenuItem>
                <ContextMenuItem>Team</ContextMenuItem>
                <ContextMenuItem>Subscription</ContextMenuItem>
            </ContextMenuContent>
        </ContextMenu>
        
    )
}