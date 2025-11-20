export type Language = {
    doneTitle?: string
    saveTitle?: string
    clearAllTitle?: string
    cameraTitle?: string
    galleryTitle?: string
    uploadDialogTitle?: string
    uploadPickerTitle?: string
    directoryCreateFail?: string
    accessMediaPermissionsMsg?: string
    continueTxt?: string
    notNow?: string
    mediaAccessDeniedMsg?: string
    saveImageSucceed?: string
    eraserTitle?: string
}

export interface PhotoEditorResult {
    imagePath: string
    messageText?: string
}

export interface PhotoEditorProps {
    path: string
    messageText?: string
    colors?: string[]
    stickers?: string[]
    hiddenControls?: ('text' | 'clear' | 'draw' | 'save' | 'share' | 'sticker' | 'crop')[]
    languages: Language
    onDone?: (result: PhotoEditorResult) => void
    onCancel?: (resultCode: number) => void
}

export default class PhotoEditor {
    static Edit({
        stickers,
        hiddenControls,
        colors,
        onDone,
        onCancel,
        ...props
    }: PhotoEditorProps): void
}
