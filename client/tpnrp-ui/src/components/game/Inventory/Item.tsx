import { ContextMenu, ContextMenuTrigger, ContextMenuItem, ContextMenuContent } from "@/components/ui/context-menu"
import { HoverCard, HoverCardContent, HoverCardTrigger } from "@/components/ui/hover-card"
import { ItemContent, ItemMedia, ItemTitle } from "@/components/ui/item"

import { Item } from "@/components/ui/item"

import beerPath from "@/assets/images/items/beer.png"
import { Badge } from "@/components/ui/badge"
import type { TInventoryItemProps } from "@/types/inventory"

export const InventoryItem = (props: TInventoryItemProps) => {
    const { item, slot } = props
    return (
        <ContextMenu>
            <ContextMenuTrigger>
                <HoverCard>
                    <HoverCardTrigger>
                        <div className="w-full h-30 bg-accent rounded">
                            <Item className="relative">
                                <Badge className="absolute -top-1.5 -left-1.5 rounded [clip-path:polygon(0_0,100%_0,100%_calc(100%-8px),calc(100%-8px)_100%,0_100%)]!">
                                    1
                                </Badge>
                                <div className="absolute top-1 right-1 text-xs p-1">
                                    1
                                </div>
                                <ItemMedia className="w-full object-cover">
                                    <img src={beerPath} alt="Item" className="w-full h-full object-cover" />
                                </ItemMedia>
                                <ItemContent className="items-center justify-center">
                                    <ItemTitle>Beer</ItemTitle>
                                </ItemContent>
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