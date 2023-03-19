export enum TableColTypes { STRING, NUMBER, BOOLEAN, LINK, IMAGE, BUTTON, LIST, ENUM }

export enum TableStates { VIEWING, EDITING, DELETING, CREATING, FEEDBACK };

export enum TableButtonTypes { EDIT, DELETE, CREATE }

export type TableDefinition = {
    showHeading?: boolean,
    showBackground?: boolean,
}

export type TableColumns = Array<TableCell>;

export type TableCell = {
    id: string, 
    title: string, 
    span: number, 
    type: TableColTypes,

    sort?: boolean,

    button?: ButtonDetails, 
    headingButton?: ButtonDetails,
    list?: ListDetails,
    enum?: EnumDetails
};

export type ButtonDetails = {
    type?: TableButtonTypes,
    click?: (data: object) => void, 
    action?: (data: object, done:(result: ResultType)=>void) => void, 
    color: string,
    title: string
}

export type ListDetails = {
    extractItems: (details: object) => Array<string>
}

export type EnumDetails = {
    enumName: string
}

export type ResultType = {
    ok?: object,
    error?: string
}