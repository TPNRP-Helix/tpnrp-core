import * as React from "react"
import * as DialogPrimitive from "@radix-ui/react-dialog"

import { cn } from "@/lib/utils"

function Dialog({
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Root>) {
  return <DialogPrimitive.Root data-slot="dialog" {...props} />
}

function DialogTrigger({
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Trigger>) {
  return <DialogPrimitive.Trigger data-slot="dialog-trigger" {...props} />
}

function DialogPortal({
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Portal>) {
  return <DialogPrimitive.Portal data-slot="dialog-portal" {...props} />
}

function DialogClose({
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Close>) {
  return <DialogPrimitive.Close data-slot="dialog-close" {...props} />
}

function DialogOverlay({
  className,
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Overlay>) {
  return (
    <DialogPrimitive.Overlay
      data-slot="dialog-overlay"
      className={cn(
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 fixed inset-0 z-50 bg-black/50 backdrop-blur",
        className
      )}
      {...props}
    />
  )
}

function DialogContent({
  className,
  children,
  showCloseButton = true,
  title = "Dialog title",
  contentClassName,
  isHaveBackdropFilter = false,
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Content> & {
  showCloseButton?: boolean
  title?: string
  contentClassName?: string
  isHaveBackdropFilter?: boolean
}) {
  return (
    <DialogPortal data-slot="dialog-portal">
      <DialogOverlay />
      <DialogPrimitive.Content
        data-slot="dialog-content"
        aria-describedby=''
        className={cn(
          "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 fixed top-[50%] left-[50%] z-50 grid w-full max-w-[calc(100%-2rem)] translate-x-[-50%] translate-y-[-50%] gap-4 rounded-lg border p-6 shadow-lg duration-200 sm:max-w-lg",
          "rounded rounded-tl-none border-none p-0 outline-none! shadow-none!",
          className
        )}
        {...props}
      >
        <DialogTitle isHaveBackdropFilter={isHaveBackdropFilter}>{title}</DialogTitle>
        {showCloseButton && (
          <DialogClose asChild>
            <button
                className="absolute -right-3.5 -top-3.5 hover:opacity-90 hover:scale-105 active:scale-95 transition z-10"
                aria-label="Close"
            >
                <svg width="32" height="32" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <g transform="scale(-1,1) translate(-64,0)">
                        <path d="M8 0H56C60.4183 0 64 3.58172 64 8V48L48 64H8C3.58172 64 0 60.4183 0 56V8C0 3.58172 3.58172 0 8 0Z" fill="#E53935"/>
                        <path d="M21 21L43 43M43 21L21 43" stroke="white" strokeWidth="5" strokeLinecap="round"/>
                    </g>
                </svg>
            </button>
          </DialogClose>
        )}
        <div className={cn("bg-background flex flex-col gap-4 rounded rounded-tl-none h-full w-full [clip-path:polygon(0_0,100%_0,100%_calc(100%-8px),calc(100%-8px)_100%,0_100%)]!",
          contentClassName,
          {
            "bg-background/50 backdrop-blur": isHaveBackdropFilter,
          }
          )}>
          {children}
        </div>
      </DialogPrimitive.Content>
    </DialogPortal>
  )
}

function DialogHeader({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="dialog-header"
      className={cn("flex flex-col gap-2 text-center sm:text-left px-4 pt-4", className)}
      {...props}
    />
  )
}

function DialogFooter({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="dialog-footer"
      className={cn(
        "flex flex-col-reverse gap-2 sm:flex-row sm:justify-end",
        "p-4 border-t bg-neutral-900 border-white/10",
        className
      )}
      {...props}
    />
  )
}

function DialogTitle({
  className,
  isHaveBackdropFilter = false,
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Title> & {
  isHaveBackdropFilter?: boolean
}) {
  return (
    <DialogPrimitive.Title
      data-slot="dialog-title"
      className={cn("text-lg leading-none font-semibold text-primary uppercase absolute -top-[24px] left-0 pl-2 pr-6 h-7 min-w-40 flex items-center justify-center gap-1.5", className)}
      {...props}
    >
      {props.children}
      <svg className={cn("absolute -z-1 inset-0 w-full h-full opacity-100",
        {
          "opacity-60": isHaveBackdropFilter,
        }
      )} viewBox="0 0 162 29" fill="none"
      preserveAspectRatio="none"
      >
          <path d="M0 28.0332H162V14.6376C162 13.4903 161.507 12.3983 160.647 11.639L148.635 1.03454C147.904 0.389288 146.963 0.0331955 145.988 0.0331955H3C1.34314 0.0331955 0 1.37634 0 3.0332V28.0332Z" fill="var(--background)" fillOpacity="1"></path>
      </svg>
    </DialogPrimitive.Title>
  )
}

function DialogDescription({
  className,
  ...props
}: React.ComponentProps<typeof DialogPrimitive.Description>) {
  return (
    <DialogPrimitive.Description
      data-slot="dialog-description"
      className={cn("text-muted-foreground text-sm", className)}
      {...props}
    />
  )
}

export {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogOverlay,
  DialogPortal,
  DialogTitle,
  DialogTrigger,
}
