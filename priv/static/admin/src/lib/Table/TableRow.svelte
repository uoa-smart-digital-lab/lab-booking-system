<script lang="ts">
	import { Badge, Button, Grid, Stack, Image } from '@svelteuidev/core';
    import { Checkbox, Cross2 } from 'radix-icons-svelte';
    import type { TableColumns, TableDefinition } from './TableTypes';
    import { TableColTypes } from './TableTypes';
	import { createEventDispatcher } from 'svelte';

    const dispatch = createEventDispatcher();

    // -------------------------------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------------------------------
    export let row : object;
    export let columns : TableColumns;
    export let rowNumber : number;
    export let enums: object;
    export let definition: TableDefinition;
    export let preProcessRow: (row: object) => {};

    let processedrow: object;
    $: {
        processedrow = preProcessRow(row);
    }

    let width = columns.reduce((acc, cell) => acc + cell.span, 0);

</script>

<style>

</style>

<Grid spacing={1} cols={width}>
    {#each columns as column}
        <Grid.Col span={column.span} override={{ backgroundColor: definition.showBackground?(rowNumber&1?'$gray100':'$gray50'):"", minHeight: 40, alignItems: 'center', textAlign: 'center', justifyContent: 'center', display:'flex' }}>
            {#if processedrow.hasOwnProperty(column.id)}
                {#if column.type === TableColTypes.STRING}
                    {processedrow[column.id]}

                {:else if column.type === TableColTypes.NUMBER}
                    {processedrow[column.id]}

                {:else if column.type === TableColTypes.BOOLEAN}
                    {#if processedrow[column.id]}
                        <Checkbox size={20} />
                    {:else}
                        <Cross2 size={20} />
                    {/if}

                {:else if column.type === TableColTypes.LINK}
                    <a href={processedrow[column.id]}>link</a>

                {:else if column.type === TableColTypes.IMAGE}
                    <Image fit='contain' src={processedrow[column.id]} height={30}/>

                {:else if column.type === TableColTypes.BUTTON}
                    <Button variant="light" fullSize color={column.button.color} on:click={()=>{
                        if (column.button.hasOwnProperty("type")) {
                            dispatch ('buttonClick', { type : column.button.type, data : {row: processedrow, cell: column.button} });
                        }                        
                        else {
                            column.button.click(row);
                        }
                    }}>{column.button.title}</Button>

                {:else if column.type === TableColTypes.LIST}
                    <Stack align="center" spacing="xs">
                        {#each column.list.extractItems(processedrow[column.id]) as text}
                            <Badge color="lime" size="md" radius="sm" variant="filled">{text}</Badge>
                        {/each}
                    </Stack>

                {:else if column.type === TableColTypes.ENUM}
                    {#if (enums.hasOwnProperty(column.enum.enumName))}
                        <Badge color="teal" size="md" radius="sm" variant="filled">{processedrow[column.id]}</Badge>
                    {:else}
                        {processedrow[column.id]}
                    {/if}

                {:else}
                    {processedrow[column.id]}
                {/if}
            {:else}
                {#if column.type === TableColTypes.BUTTON}
                    <Button variant="light" fullSize color={column.button.color} on:click={()=>{
                        if (column.button.hasOwnProperty("type")) {
                            dispatch ('buttonClick', { type : column.button.type, data : {row: processedrow, cell: column.button} });
                        }                        
                        else {
                            column.button.click(row);
                        }
                    }}>{column.button.title}</Button>
                {:else}
                    &nbsp;
                {/if}                
            {/if}
        </Grid.Col>
    {/each}
</Grid>
