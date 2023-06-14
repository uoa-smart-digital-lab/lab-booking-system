<!------------------------------------------------------------------------------------------------------
  Login dialog box

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { Table, Table_Col, Table_Row, Table_Body, Table_Foot, Table_Head, Input, Dropdown, Menu, Item, Button, Icon, Text, Buttons } from "svelte-fomantic-ui";
    import { getKeys, getFormat } from "./Graphql.svelte";

    export let definition: string = "";
    export let data: any[] = [];

    const format = getFormat(definition);
    const keys = getKeys(definition);

    console.log(keys, format);
</script>


<Table ui stackable compact>
    <Table_Head>
        <Table_Row>
            {#each getKeys(definition) as title, i}
                <Table_Col head center aligned>
                    {title}
                </Table_Col>
            {/each}
        </Table_Row>
    </Table_Head>

    <Table_Body>
        {#each data as row, i}
            <Table_Row>
                {#each getKeys(definition) as col, i}
                    <Table_Col center aligned>
                        {#if format[col].type === "string" || format[col].type === "number" || format[col].type === "boolean" || format[col].type === "Date"}
                            {row[col]}
                        {:else if format[col].type === "array"}
                            {row[col]}
                        {:else if format[col].type === "object"}
                            <Dropdown ui fluid selection selected={data[col].status.toString()} on:change={(item) => {data[col].status=Number(item.detail.value)}}>
                                <Input hidden bind:value={data[col].status}/>
                                <Icon dropdown/>
                                <Text default>Select Status</Text>
                                <Menu fluid>
                                    <Item value="0">student</Item>
                                    <Item value="1">staff</Item>
                                    <Item value="2">admin</Item>
                                </Menu>
                            </Dropdown>
                        {/if}
                    </Table_Col>
                {/each}
            </Table_Row>
        {/each}
    </Table_Body>

</Table>


