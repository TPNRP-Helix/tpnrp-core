import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { useDevModeStore } from "@/stores/useDevModeStore"


const PreviewUI = () => {
    return (
        <>
            <div className="grid gap-2">
                <Progress value={50} />
            </div>
        </>
    )
}

export const UIPreview = () => {
    const { isUIPreviewOpen, setUIPreviewOpen } = useDevModeStore()

    return isUIPreviewOpen ? (
        <div className="p-4">
            <h1>UIPreview</h1>
            <Button onClick={() => setUIPreviewOpen(false)}>Close</Button>
            <div className="grid grid-cols-2 gap-2">
                <Card className="bg-foreground text-background">
                    <CardHeader>
                        <CardTitle>Light</CardTitle>
                        <CardDescription>Light preview</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <PreviewUI />
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader>
                        <CardTitle>Dark</CardTitle>
                        <CardDescription>Dark preview</CardDescription>
                    </CardHeader>
                    <CardContent>
                        <PreviewUI />
                    </CardContent>
                </Card>
            </div>
        </div>
    ) : null
}