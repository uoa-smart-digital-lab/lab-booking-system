<script lang="ts">
	import { Grid, Button, Column, Icon, Table_Row } from 'svlete-fomantic-ui';
    import type { TableColumns, TableDefinition } from './TableTypes';
	import { createEventDispatcher } from 'svelte';

    const dispatch = createEventDispatcher();

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let columns : TableColumns;
    export let definition: TableDefinition;
    export let sortkey: string;

    let width = columns.reduce((acc, cell) => acc + cell.span, 0);
</script>

<style>

</style>

<Table_Row spacing={1} cols={width}>
    {#each columns as column }
        <Column span={column.span} style={{ backgroundColor: '$gray200', minHeight: 40, alignItems: 'center', textAlign: 'center', justifyContent: 'center', display:'flex' }}>
            {#if column.headingButton}
                <Button ui basic fluid _={column.headingButton.color} on:click={()=>{
                    if (column.headingButton.hasOwnProperty("type")) {
                        dispatch ('buttonClick', { type : column.headingButton.type, data : {row: {}, cell: column.headingButton}});
                    }                        
                    else {
                        column.headingButton.click({"action":column.headingButton.title});
                    }
                }}>{column.headingButton.title}</Button>
            {:else}
                {column.title}
                {#if column.sort}
                    <Button ui basic on:click={()=>{sortkey=column.id}}><Icon angle up/></Button>
                {/if}
            {/if}                 
        </Column>
    {/each}
</Table_Row>
