import { useCallback, useState } from "react"

type TImageProps = {
    src: string
    alt: string
    fallbackSrc?: string
    onError?: () => void
}


export function Image({
    className,
    alt,
    fallbackSrc,
    ...props
  }: React.ComponentProps<"img"> & TImageProps) {
    const [src, setSrc] = useState(props.src)
    
    const onError = useCallback(() => {
        setSrc(fallbackSrc ?? '')
    }, [fallbackSrc])

    return (
        <img alt={alt} onError={onError} className={className} {...props} src={src} />
    )
  }