<!------------------------------------------------------------------------------------------------------
  Login dialog box

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { Table, Table_Col, Table_Row, Table_Body, Table_Foot, Table_Head, Checkbox, Image, Input, Dropdown, Link, Menu, Item, Button, Icon, Text, Buttons } from "svelte-fomantic-ui";
    import { getKeys, getFormat, totalWidth, proportionalWidth } from "./Graphql.svelte";

    export let definition: string = "";
    export let data: any[] = [];

    const format = getFormat(definition);
    const keys = getKeys(definition);
    const width = totalWidth(format);

    console.log(keys, format, width);
</script>


<Table ui stackable compact celled>
    <Table_Head>
        <Table_Row>
            {#each keys as title, i}
                <Table_Col head center aligned style={"width:" + proportionalWidth(format, width, title) + "%"}>
                    {title}
                </Table_Col>
            {/each}
        </Table_Row>
    </Table_Head>

    <Table_Body>
        {#each data as row, i}
            <Table_Row>
                {#each keys as col, i}
                    <Table_Col center aligned>
                        {#if format[col].input === "text" || format[col].input === "number"}
                            {format[col].capitalise ? row[col].toUpperCase() : row[col]}
                        {:else if format[col].input === "checkbox"}
                            <Checkbox checked={row[col]}/>
                        {:else if format[col].input === "date"}
                            {row[col]}
                        {:else if format[col].input === "image"}
                            <Link href={row[col]}><Image ui avatar src={row[col]}/>{row[col]}</Link>
                        {:else if format[col].input === "url"}
                            <Link href={row[col]}>{row[col]}</Link>
                        {:else if format[col].input === "array"}
                            {row[col]}
                        {:else if format[col].input === "dropdown"}
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
                        {/if}
                    </Table_Col>
                {/each}
            </Table_Row>
        {/each}
    </Table_Body>

</Table>


