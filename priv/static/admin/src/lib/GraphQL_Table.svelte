<!------------------------------------------------------------------------------------------------------
  Login dialog box

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { Table, Table_Col, Table_Row, Table_Body, Table_Foot, Table_Head, Input, Dropdown, Menu, Item, Button, Icon, Text, Buttons } from "svelte-fomantic-ui";
    import { getKeys } from "./Graphql.svelte";

    export let definition: string = "";
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
</Table>


