<!------------------------------------------------------------------------------------------------------
  Login dialog box

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { Table, Table_Col, Table_Row, Table_Body, Table_Foot, Table_Head, Input, Dropdown, Menu, Item, Button, Icon, Text, Buttons } from "svelte-fomantic-ui";
    import { getKeys, getTypes } from "./Graphql.svelte";
    import type {BookingTypes} from "./Graphql.svelte";

    export let definition: string = "";
    export let data: BookingTypes[] = [];

    const types = getTypes(definition);
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
                        {#if types[i] === "string" || types[i] === "number" || types[i] === "boolean" || types[i] === "Date"}
                            {row[col]}
                        {:else if types[i] === "array"}
                            {row[col]}
                        {/if}
                    </Table_Col>
                {/each}
            </Table_Row>
        {/each}
    </Table_Body>

</Table>


