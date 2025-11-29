import { useCallback, useState, useEffect, useRef } from "react"

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
    src: propsSrc,
    ...props
  }: React.ComponentProps<"img"> & TImageProps) {
    const [src, setSrc] = useState(propsSrc)
    const [hasError, setHasError] = useState(false)
    const prevSrcRef = useRef(propsSrc)
    
    useEffect(() => {
        if (propsSrc !== prevSrcRef.current) {
            prevSrcRef.current = propsSrc
            setHasError(false)
            setSrc(propsSrc)
        }
    }, [propsSrc])
    
    const onError = useCallback(() => {
        if (!hasError && fallbackSrc) {
            setHasError(true)
            setSrc(fallbackSrc)
        }
    }, [fallbackSrc, hasError])

    return (
        <img alt={alt} onError={onError} className={className} {...props} src={src} />
    )
  }