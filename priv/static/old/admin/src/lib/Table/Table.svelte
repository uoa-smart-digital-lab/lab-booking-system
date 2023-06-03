<!------------------------------------------------------------------------------------------------------
  All the items in the system
------------------------------------------------------------------------------------------------------->
<script lang="ts">
	import { Image, Modal, Title, Divider, Grid, Button, Stack, TextInput, Dropdown } from 'svelte-fomantic-ui';
    import TableRow from './TableRow.svelte';
    import TableHeadings from './TableHeadings.svelte';
    import type { ResultType, TableCell, TableColumns, TableDefinition } from './TableTypes';
    import { TableColTypes, TableStates, TableButtonTypes } from './TableTypes';

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let definition: TableDefinition;
    export let columns: TableColumns;
    export let enums: object;
    export let data: Array<object>;
    export let searchString : string;
    export let checkSearch: (cell: object, searchString: string)=>{};
    export let preProcessRow: (row: object) => {}
    export let postProcessRow: (row: object) => {}
    
    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let sorted = data;
    let sortkey: string = "";

    let currentState: TableStates = TableStates.VIEWING;
    let currentRow: object = null;
    let currentCell: TableCell = null;
    let currentMessage = "";

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------

    $: {
        if (sortkey !== "")
        {
            if (data[0].hasOwnProperty(sortkey)) {
                sorted = data.concat().sort((a:any, b:any) => (a[sortkey] < b[sortkey] ? -1 : 1))
            }
        }
    }

    function buttonClick (event : any) {
        console.log(event);
        switch (event.detail.type)
        {
            case TableButtonTypes.CREATE : currentState = TableStates.CREATING; currentRow = {};                    currentCell = event.detail.data.cell; break;
            case TableButtonTypes.DELETE : currentState = TableStates.DELETING; currentRow = event.detail.data.row; currentCell = event.detail.data.cell; break;
            case TableButtonTypes.EDIT :   currentState = TableStates.EDITING;  currentRow = event.detail.data.row; currentCell = event.detail.data.cell; break;
            default: break;
        }
    }

    function backToTable () {
        currentState = TableStates.VIEWING;
    }

    function doDelete () {
        console.log("Deleting");
        currentCell.button.action(currentRow, (answer: ResultType) => {
            if (answer.ok)
            {
                currentMessage = (answer.ok.hasOwnProperty("name")?answer.ok["name"]:"object") + " deleted";
            }
            else if (answer.error)
            {
                currentMessage = answer.error;
            }
            else
            {
                currentMessage = "something went wrong";
            }
            currentState = TableStates.FEEDBACK;
        })
    }

    function doCreate () {
        console.log("Creating");
        console.log(currentRow);
        let processedRow = postProcessRow(currentRow);
        console.log(processedRow);
        console.log(currentCell);
        currentCell.headingButton.action(processedRow, (answer: ResultType) => {
            if (answer.ok)
            {
                currentMessage = (answer.ok.hasOwnProperty("name")?answer.ok["name"]:"object") + " created";
            }
            else if (answer.error)
            {
                currentMessage = answer.error;
            }
            else
            {
                currentMessage = "something went wrong";
            }
            currentState = TableStates.FEEDBACK;
        })
    }

    function doEdit () {
        console.log("Editing");
        let processedRow = postProcessRow(currentRow);
        console.log(processedRow);
        currentCell.button.action(processedRow, (answer: ResultType) => {
            if (answer.ok)
            {
                currentMessage = (answer.ok.hasOwnProperty("name")?answer.ok["name"]:"object") + " saved";
            }
            else if (answer.error)
            {
                currentMessage = answer.error;
            }
            else
            {
                currentMessage = "something went wrong";
            }
            currentState = TableStates.FEEDBACK;
        })
    }

    function handleString (event: any) {
        currentRow[event.target.name] = event.target.value;
    }
    
</script>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Styles
------------------------------------------------------------------------------------------------------->
<style>

</style>
<!----------------------------------------------------------------------------------------------------->



<!------------------------------------------------------------------------------------------------------
Layout
------------------------------------------------------------------------------------------------------->
<Stack align="strech" override={{width:"100%", gap:"1px"}}>
    {#if definition.showHeading}
        <TableHeadings {definition} {columns} bind:sortkey={sortkey} on:buttonClick={buttonClick}/>
    {/if}
    {#each sorted as row, rowNumber }
        {#if (checkSearch(row, searchString))}
            <TableRow {rowNumber} {definition} {enums} {columns} {row} {preProcessRow} on:buttonClick={buttonClick}/>
        {/if}
    {/each}
</Stack>

<Modal ui size="sm" opened={(currentState === TableStates.EDITING) || (currentState === TableStates.CREATING)} on:close={backToTable} withCloseButton={false}>
    <Grid  cols={1} spacing="xs">
        {#each columns as column}
            {#if column.type === TableColTypes.STRING}
                <TextInput label={column.title} name={column.id} placeholder={column.title} on:input={handleString} value={(currentState === TableStates.EDITING)?currentRow[column.id]:""}/>
            {:else if column.type === TableColTypes.NUMBER}
                <TextInput label={column.title} name={column.id} placeholder={column.title} on:input={handleString} value={(currentState === TableStates.EDITING)?currentRow[column.id]:""}/>
            {:else if column.type === TableColTypes.LINK}
                <TextInput label={column.title} name={column.id} placeholder={column.title} on:input={handleString} value={(currentState === TableStates.EDITING)?currentRow[column.id]:""}/>
            {:else if column.type === TableColTypes.IMAGE}
                <TextInput label={column.title} name={column.id} placeholder={column.title} on:input={handleString} value={(currentState === TableStates.EDITING)?currentRow[column.id]:""}/>
            {:else if column.type === TableColTypes.ENUM}
                <Dropdown data={enums[column.enum.enumName]} placeholder={column.title} label={column.title} value={(currentState === TableStates.EDITING)?currentRow[column.id]:""}/>
            {/if}
        {/each}
    </Grid>
    <Divider variant='dotted'/>
    <Grid cols={2}>
        <Button ui on:click={backToTable} blue fliud>
            Cancel
        </Button>
        {#if (currentState === TableStates.EDITING)}
            <Button ui on:click={doEdit} green fluid>
                Save
            </Button>
        {:else}
            <Button ui on:click={doCreate} green fluid>
                Create
            </Button>
        {/if}
    </Grid>
</Modal>

<Modal size="sm" opened={currentState === TableStates.DELETING} on:close={backToTable} withCloseButton={false}>
    <Stack align="center">
        <Title order={3}>Are you sure you want to delete</Title> 
        <Title order={3}>{currentRow.hasOwnProperty("name")?currentRow["name"]:"this object"}</Title>
    </Stack>
    <Divider variant='dotted'/>
    {#if currentRow.hasOwnProperty("image")}
        <Image src={currentRow["image"]} />
    {/if}
    <Divider variant='dotted'/>
    <SimpleGrid cols={2}>
        <Button on:click={backToTable} variant='filled' color='blue' fullSize>
            Cancel
        </Button>
        <Button on:click={doDelete} variant='filled' color='red' fullSize>
            Delete
        </Button>
    </SimpleGrid>
</Modal>

<Modal size="sm" opened={currentState === TableStates.FEEDBACK} on:close={backToTable} withCloseButton={false}>
    <Stack align="center">
        <Title order={3}>{currentMessage}</Title>
    </Stack>
    <Divider variant='dotted'/>
    <SimpleGrid cols={1}>
        <Button on:click={backToTable} variant='filled' color='blue' fullSize>
            OK
        </Button>
    </SimpleGrid>
</Modal>
<!----------------------------------------------------------------------------------------------------->