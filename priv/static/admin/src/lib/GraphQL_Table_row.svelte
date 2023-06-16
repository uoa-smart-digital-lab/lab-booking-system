<!------------------------------------------------------------------------------------------------------
  Login dialog box

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { reload, Table, Table_Col, Table_Row, Table_Body, Table_Foot, Table_Head, Checkbox, Image, Label, Popup, Calendar, Input, Dropdown, Link, Menu, Item, Button, Icon, Text, Buttons } from "svelte-fomantic-ui";
    import { getKeys, getFormat, totalWidth, proportionalWidth } from "./Graphql.svelte";
    import { onMount } from "svelte";

    export let col: string = "";
    export let row: any = {};
    export let format: any = {};
    export let horizontal = false;

    onMount(() => {
        reload();
    });
    function extract (data:any[], keystring:string) {
        let result = data;
        let keys = keystring.split('.');
        for (let i = 0; i < keys.length; i++) {
            if (result !== undefined) result = result[keys[i]];
        }
        return result;
    }
</script>

{#if horizontal}
    <Table_Col center aligned>
        {col}
    </Table_Col>
{/if}
<Table_Col center aligned>
    {#if (format[col].input === "text" || format[col].input === "number") && row[col] !== undefined}
        {format[col].capitalise ? row[col].toUpperCase() : row[col]}
    {:else if format[col].input === "checkbox" && row[col] !== undefined}
        <Checkbox checked={row[col]}/>
    {:else if format[col].input === "datetime" && row[col] !== undefined}
        <Label ui green>{row[col].toLocaleString('en-US', { timeZone: 'UTC', dateStyle: 'short', timeStyle: 'short' })}</Label>
    {:else if format[col].input === "image" && row[col] !== undefined}
        <Link href={row[col]}><Image ui avatar src={row[col]}/>{row[col]}</Link>
    {:else if format[col].input === "url" && row[col] !== undefined}
        <Link href={row[col]}>{row[col]}</Link>
    {:else if format[col].input === "object" && row[col] !== undefined}
        <svelte:self horizontal definition={format[col].type} data={[row[col]]}/>
    {:else if format[col].input === "array" && row[col] !== undefined}
        {#if format[col].hasOwnProperty("labelise")}
            {#each row[col] as item, i}
                <Label ui blue popup={{hoverable: true}}>{extract(item, format[col].labelise)}</Label>
                <Popup ui>
                    <svelte:self definition={format[col].type} data={[item]}/>
                </Popup>
            {/each}
        {:else}
            <svelte:self definition={format[col].type} data={[row[col]]}/>
        {/if}
    {:else if format[col].input === "dropdown" && row[col] !== undefined}
        <!-- <Dropdown ui fluid selection selected={data[col].status.toString()} on:change={(item) => {data[col].status=Number(item.detail.value)}}>
            <Input hidden bind:value={data[col].status}/>
            <Icon dropdown/>
            <Text default>Select Status</Text>
            <Menu fluid>
                <Item value="0">student</Item>
                <Item value="1">staff</Item>
                <Item value="2">admin</Item>
            </Menu>
        </Dropdown> -->
        {"dropdown"}
    {:else}
        ---
    {/if}
</Table_Col>
