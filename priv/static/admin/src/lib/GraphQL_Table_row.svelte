<!------------------------------------------------------------------------------------------------------
  Login dialog box

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { Table_Col, Checkbox, Image, Label, Popup, Link, Button, Icon, Select, Option } from "svelte-fomantic-ui";
    import { typeDropdown } from "./Graphql.svelte";
    import GraphQL_Table from "./GraphQL_Table.svelte";

    export let col: string = undefined;
    export let row: any = {};
    export let format: any = {};
    export let horizontal = false;

    function extract(data:any[], keystring:string) { return keystring.split('.').reduce((result, key) => result !== undefined ? result[key] : undefined, data); }
</script>

{#if col && col !== ""}
    {#if horizontal}
        <Table_Col center aligned>
            {col}
        </Table_Col>
    {/if}
    <Table_Col center aligned>
        {#if (format[col].input === "text" || format[col].input === "number") && row[col] !== undefined}
            {format[col].capitalise ? row[col].toUpperCase() : row[col]}
        {:else if format[col].input === "checkbox" && row[col] !== undefined}
            <Checkbox ui checked={row[col]} read-only/>
        {:else if format[col].input === "datetime" && row[col] !== undefined}
            <Label ui green>{row[col].toLocaleString('en-US', { timeZone: 'UTC', dateStyle: 'short', timeStyle: 'short' })}</Label>
        {:else if format[col].input === "image" && row[col] !== undefined}
            <Link href={row[col]} popup={{hoverable:true}}><Image ui avatar src={row[col]}/>{row[col]}</Link>
            <Popup ui flowing>
                <Image ui medium src={row[col]}/>
            </Popup>
        {:else if format[col].input === "url" && row[col] !== undefined}
            <Link href={row[col]} target="_blank">{row[col]}</Link>
        {:else if format[col].input === "object" && row[col] !== undefined}
            <GraphQL_Table horizontal definition={format[col].type} data={[row[col]]}/>
        {:else if format[col].input === "array" && row[col] !== undefined}
            {#if row[col].length === 0}
                <Button ui green icon compact tertiary>
                    <Icon plus/>
                </Button>
            {:else}
                {#if format[col].hasOwnProperty("labelise")}
                    {#each row[col] as item, i}
                        <Label ui tag popup={{hoverable: true}}>{extract(item, format[col].labelise)}</Label>
                        <Popup ui flowing>
                            <GraphQL_Table definition={format[col].type} data={[item]}/>
                        </Popup>
                    {/each}
                {:else}
                    <GraphQL_Table definition={format[col].type} data={[row[col]]}/>
                {/if}
            {/if}
        {:else if format[col].input === "dropdown" && row[col] !== undefined}
            <Select ui read-only dropdown bind:value={row[col]}>
                {#each typeDropdown(format[col].type) as item}
                    <Option value={Object.keys(item)[0]}>{item[Object.keys(item)[0]]}</Option>
                {/each}
            </Select>
        {:else}
            ---
        {/if}
    </Table_Col>
{/if}
