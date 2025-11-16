import * as React from "react"
import * as SheetPrimitive from "@radix-ui/react-dialog"

import { cn } from "@/lib/utils"
import { DialogTitle } from "./dialog"

function Sheet({ ...props }: React.ComponentProps<typeof SheetPrimitive.Root>) {
  return <SheetPrimitive.Root data-slot="sheet" {...props} />
}

function SheetTrigger({
  ...props
}: React.ComponentProps<typeof SheetPrimitive.Trigger>) {
  return <SheetPrimitive.Trigger data-slot="sheet-trigger" {...props} />
}

function SheetClose({
  ...props
}: React.ComponentProps<typeof SheetPrimitive.Close>) {
  return <SheetPrimitive.Close data-slot="sheet-close" {...props} />
}

function SheetPortal({
  ...props
}: React.ComponentProps<typeof SheetPrimitive.Portal>) {
  return <SheetPrimitive.Portal data-slot="sheet-portal" {...props} />
}

function SheetOverlay({
  className,
  ...props
}: React.ComponentProps<typeof SheetPrimitive.Overlay>) {
  return (
    <SheetPrimitive.Overlay
      data-slot="sheet-overlay"
      className={cn(
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 fixed inset-0 z-50 bg-black/50",
        className
      )}
      {...props}
    />
  )
}

function SheetContent({
  className,
  children,
  isShowOverlay = true,
  isShowCloseButton = true,
  side = "right",
  title = "Sheet title",
  ...props
}: React.ComponentProps<typeof SheetPrimitive.Content> & {
  side?: "top" | "right" | "bottom" | "left"
  isShowOverlay?: boolean
  isShowCloseButton?: boolean
  title?: string
}) {
  return (
    <SheetPortal>
      {isShowOverlay && <SheetOverlay />}
      <SheetPrimitive.Content
        data-slot="sheet-content"
        className={cn(
          "border-none data-[state=open]:animate-in data-[state=closed]:animate-out fixed z-50 flex flex-col gap-4 transition ease-in-out data-[state=closed]:duration-300 data-[state=open]:duration-500 rounded top-1/2! -translate-y-1/2",
          side === "right" &&
            "data-[state=closed]:slide-out-to-right data-[state=open]:slide-in-from-right inset-y-0 right-4 h-[80%] w-3/4 sm:max-w-sm",
          side === "left" &&
            "data-[state=closed]:slide-out-to-left data-[state=open]:slide-in-from-left inset-y-0 left-2 h-[80%] w-3/4 sm:max-w-sm",
          side === "top" &&
            "data-[state=closed]:slide-out-to-top data-[state=open]:slide-in-from-top inset-x-0 top-0 h-auto border-b",
          side === "bottom" &&
            "data-[state=closed]:slide-out-to-bottom data-[state=open]:slide-in-from-bottom inset-x-0 bottom-0 h-auto border-t",
          className
        )}
        {...props}
      >
        <DialogTitle>{title}</DialogTitle>
        <div
          className={cn(
            "bg-background flex flex-col gap-4 rounded rounded-tl-none h-full w-full",
            side === "right" && "[clip-path:polygon(0_0,100%_0,100%_100%,8px_100%,0_calc(100%-8px))]",
            side === "left" && "[clip-path:polygon(0_0,100%_0,100%_calc(100%-8px),calc(100%-8px)_100%,0_100%)]!"
          )}>
          {children}
        </div>
        {isShowCloseButton && (
          <SheetPrimitive.Close className="ring-offset-background focus:ring-ring data-[state=open]:bg-secondary absolute -right-3.5 -top-3.5 hover:opacity-90 hover:scale-105 active:scale-95 transition rounded-xs focus:outline-hidden disabled:pointer-events-none">
            <svg className="w-8 h-8" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
              <g transform="scale(-1,1) translate(-64,0)">
                  <path d="M8 0H56C60.4183 0 64 3.58172 64 8V48L48 64H8C3.58172 64 0 60.4183 0 56V8C0 3.58172 3.58172 0 8 0Z" fill="#E53935"/>
                  <path d="M21 21L43 43M43 21L21 43" stroke="white" strokeWidth="5" strokeLinecap="round"/>
              </g>
            </svg>
            <span className="sr-only">Close</span>
          </SheetPrimitive.Close>
        )}
      </SheetPrimitive.Content>
    </SheetPortal>
  )
}

function SheetHeader({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="sheet-header"
      className={cn("relative flex flex-col gap-1.5 p-0 mt-4 mx-4 min-h-7 border-b border-white/10", className)}
      {...props}
    />
  )
}

function SheetBody({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="sheet-body"
      className={cn("flex flex-col gap-1.5 p-4", className)}
      {...props}
    />
  )
}

function SheetFooter({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="sheet-footer"
      className={cn("mt-auto flex flex-col gap-2 p-4", className)}
      {...props}
    />
  )
}

function SheetTitle({
  className,
  ...props
}: React.ComponentProps<typeof SheetPrimitive.Title>) {
  return (
    <SheetPrimitive.Title
      data-slot="sheet-title"
      className={cn("relative text-black text-sm font-medium uppercase inline-flex items-center gap-1.5 pl-2 pr-4 py-1", className)}
      {...props}
    >
      <span className="relative z-10 flex items-center gap-1.5">
        {props.children}
      </span>
      <svg className="absolute -z-1 inset-0 w-full h-full" viewBox="0 0 162 29" fill="none" preserveAspectRatio="none">
          <path d="M0 28.0332H162V14.6376C162 13.4903 161.507 12.3983 160.647 11.639L148.635 1.03454C147.904 0.389288 146.963 0.0331955 145.988 0.0331955H3C1.34314 0.0331955 0 1.37634 0 3.0332V28.0332Z" fill="var(--foreground)" fillOpacity="0.32"></path>
      </svg>
    </SheetPrimitive.Title>
  )
}

function SheetDescription({
  className,
  ...props
}: React.ComponentProps<typeof SheetPrimitive.Description>) {
  return (
    <SheetPrimitive.Description
      data-slot="sheet-description"
      className={cn("text-muted-foreground text-sm ", className)}
      {...props}
    />
  )
}

export {
  Sheet,
  SheetTrigger,
  SheetClose,
  SheetContent,
  SheetHeader,
  SheetBody,
  SheetFooter,
  SheetTitle,
  SheetDescription,
}
