<!------------------------------------------------------------------------------------------------------
  Login dialog box

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import { behavior, reload, Table, Table_Col, Table_Row, Table_Body, Modal, Header, Content, Actions, Segment, Table_Foot, Table_Head, Checkbox, Image, Label, Popup, Calendar, Input, Dropdown, Link, Menu, Item, Button, Icon, Text, Buttons } from "svelte-fomantic-ui";
    import { getKeys, getFormat, totalWidth, proportionalWidth } from "./Graphql.svelte";
    import GraphQL_Table_row from "./GraphQL_Table_row.svelte";
    import GraphQL_Table_row_edit from "./GraphQL_Table_row_edit.svelte";

    export let definition: string = "";
    export let data: any[] = [];
    export let horizontal = false;
    export let id: string = "Table";

    let editable_content = {};


    const format = getFormat(definition);
    const keys = getKeys(definition);
    const width = totalWidth(format);

    function extract (data:any[], keystring:string) {
        let result = data;
        let keys = keystring.split('.');
        for (let i = 0; i < keys.length; i++) {
            if (result !== undefined) result = result[keys[i]];
        }
        return result;
    }

    function doEdit(content: {}) {
        editable_content = content;
        // console.log(editable_content);
        // editModal = true;
        // update("edit_modal");
        behavior({type: "modal", id: id+"edit_modal", commands: ["show"]});
    }

</script>

<!-- <Modal ui id="edit">
    <Header/>
    <Content scrolling>
        <GraphQL_Table_row_edit content={edit_content}/>
    </Content>
    <Actions/>
</Modal> -->

<GraphQL_Table_row_edit id={id+"edit_modal"} row={editable_content} {format} {keys}/>

{#if data}
    {#if horizontal}
        <div style="overflow-x: auto; max-width: 100%;">
            <Table {id} ui unstackable very compact celled definition style="min-width: 100%;">
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
        </div>
    {:else}
        <div style="overflow-x: auto; max-width: 100%;">
            <Table ui unstackable very compact celled style="min-width: 100%;">
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
                                <Button ui blue icon compact tertiary on:click={()=>{doEdit(row) }}>
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
        </div>
    {/if}
{:else}
    <p>undefined</p>
{/if}


