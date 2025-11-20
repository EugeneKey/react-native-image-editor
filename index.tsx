import { NativeModules } from 'react-native'

const { RNPhotoEditor } = NativeModules

type Language = {
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

export type PhotoEditorResult = {
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
    private static defaultProps = {
        stickers: [],
        hiddenControls: [],
        colors: [
            '#000000',
            '#808080',
            '#a9a9a9',
            '#FFFFFE',
            '#0000ff',
            '#00ff00',
            '#ff0000',
            '#ffff00',
            '#ffa500',
            '#800080',
            '#00ffff',
            '#a52a2a',
            '#ff00ff'
        ],
        languages: {
            doneTitle: 'Done',
            saveTitle: 'Save',
            clearAllTitle: 'Clear all',
            cameraTitle: 'Camera',
            galleryTitle: 'Gallery',
            uploadDialogTitle: 'Upload Image',
            uploadPickerTitle: 'Select Picture',
            directoryCreateFail: 'Failed to create directory',
            accessMediaPermissionsMsg: 'To attach photos, we need to access media on your device',
            continueTxt: 'Continue',
            notNow: 'NOT NOW',
            mediaAccessDeniedMsg: 'You denied storage access, no photos will be added.',
            saveImageSucceed: 'Image saved',
            eraserTitle: 'Eraser'
        }
    }

    static Edit({
        stickers,
        hiddenControls,
        colors,
        languages,
        onDone,
        onCancel,
        ...props
    }: PhotoEditorProps) {
        if (stickers === undefined) {
            stickers = this.defaultProps.stickers
        }
        if (hiddenControls === undefined) {
            hiddenControls = this.defaultProps.hiddenControls
        }
        if (colors === undefined) {
            colors = this.defaultProps.colors
        }

        if (languages !== undefined) {
            languages = { ...this.defaultProps.languages, ...languages }
        } else {
            languages = this.defaultProps.languages
        }

        RNPhotoEditor.Edit(
            { colors, hiddenControls, stickers, languages, ...props },
            (result: PhotoEditorResult) => {
                onDone && onDone(result)
            },
            (resultCode: number) => {
                onCancel && onCancel(resultCode)
            }
        )
    }
}
