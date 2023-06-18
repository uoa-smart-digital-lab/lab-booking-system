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
    import GraphQL_Table_row from "./GraphQL_Table_row.svelte";

    export let definition: string = "";
    export let data: any[] = [];
    export let horizontal = false;

    const format = getFormat(definition);
    const keys = getKeys(definition);
    const width = totalWidth(format);

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


{#if data}
    {#if horizontal}
        <Table ui stackable very compact celled definition>
            <Table_Body>
                {#each data as row, i}
                    {#each keys as col, i}
                        {#if row[col] !== undefined}
                            <Table_Row>
                                <GraphQL_Table_row {col} {row} {format} {horizontal}/>
                            </Table_Row>
                        {/if}
                    {/each}
                {/each}
            </Table_Body>
        </Table>
    {:else}
        <Table ui stackable very compact celled>
            <Table_Head>
                <Table_Row>
                    <Table_Col center aligned style="width: 2%">
                        <Button ui green icon compact tertiary>
                            <Icon plus/>
                        </Button>
                    </Table_Col>
                    {#each keys as title, i}
                        <Table_Col head center aligned style={"width:" + proportionalWidth(format, width, title) + "%"}>
                            {title}
                        </Table_Col>
                    {/each}
                    <Table_Col center aligned style="width: 2%">
                    </Table_Col>
                </Table_Row>
            </Table_Head>

            <Table_Body>
                {#each data as row, i}
                    <Table_Row>
                        <Table_Col center aligned>
                            <Button ui blue icon compact tertiary>
                                <Icon edit/>
                            </Button>
                        </Table_Col>
                        {#each keys as col, i}
                            <GraphQL_Table_row {col} {row} {format} {horizontal}/>
                        {/each}
                        <Table_Col center aligned>
                            <Button ui red icon compact tertiary>
                                <Icon trash/>
                            </Button>
                        </Table_Col>
                    </Table_Row>
                {/each}
            </Table_Body>
        </Table>
    {/if}
{:else}
    <p>undefined</p>
{/if}


