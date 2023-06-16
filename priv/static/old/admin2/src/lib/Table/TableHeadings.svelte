<script lang="ts">
	import { Grid, Button } from '@svelteuidev/core';
    import type { TableColumns, TableDefinition } from './TableTypes';
    import { ChevronUp } from 'radix-icons-svelte';
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

<Grid spacing={1} cols={width}>
    {#each columns as column }
        <Grid.Col span={column.span} override={{ backgroundColor: '$gray200', minHeight: 40, alignItems: 'center', textAlign: 'center', justifyContent: 'center', display:'flex' }}>
            {#if column.headingButton}
                <Button variant="light" fullSize color={column.headingButton.color} on:click={()=>{
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
                    <Button variant="subtle" on:click={()=>{sortkey=column.id}}><ChevronUp /></Button>
                {/if}
            {/if}                 
        </Grid.Col>
    {/each}
</Grid>
