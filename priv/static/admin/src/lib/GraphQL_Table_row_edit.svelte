<!------------------------------------------------------------------------------------------------------
  Login dialog box

  Author: Dr. Roy C. Davies
  Created: June 2023
  Contact: roy.c.davies@ieee.org
------------------------------------------------------------------------------------------------------->
<script lang="ts">
    import {behavior, reload, Text, Modal, Actions, Button, Content, Message, Header, Form, Checkbox, Link, Popup, Image, Icon, Select, Option, Field, Input, Label, Table, Table_Body, Table_Row, Table_Col} from "svelte-fomantic-ui";
	import { afterUpdate, createEventDispatcher } from 'svelte';
    import { typeDropdown } from "./Graphql.svelte";
    import GraphQL_Table from "./GraphQL_Table.svelte";


    export let row = {};
    export let format = {};
    export let keys = [];
    export let id: string="EditDialog"+Math.random().toString(36).substring(2, 6);
;

    // -------------------------------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------------------------------
    let errorMessage : string = "";                             // Error message
    const dispatch = createEventDispatcher();                   // Event dispatcher

    // -------------------------------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------------------------------
    // Check for enter key and call submit when detected
    const handleKeydown = (event:any) => {
		// if (event.key === 'Enter') {
        //     handleSubmit();
        // }
    }

    // The GraphQL mutation structure for login
    // const doLogin = mutation(LOGIN);

    // What do do when the enter key or login button is pressed
    const handleSubmit = () => {
        // console.log("LOGGING IN", upi, password);
        // doLogin({ variables: { upi, password } })
        // .then((result:any) => {
        //     errorMessage="";
        //     behavior(id, "hide"); 
        //     dispatch ('login', { message : 'success', data : result.data.login });
        // })
        // .catch((error : { graphQLErrors : [{ message : string }]}) => {
        //     errorMessage = convertErrorMessage(error.graphQLErrors[0].message);
        // });
    }

    function closeLogin () {
        errorMessage="";
        behavior(id, "hide"); 
        dispatch ('login', { message : 'close', data : {}})
    }

    function extract(data:any[], keystring:string) { return keystring.split('.').reduce((result, key) => result !== undefined ? result[key] : undefined, data); }

    afterUpdate(() => { reload(id); });

</script>

<Modal ui huge {id}>
    <Header>Edit {row["__typename"]}</Header>
    <Content scrolling>
        <Form ui>
            <Table ui unstackable very compact celled definition style="min-width: 100%;">
                <Table_Body>
                    {#each keys as col, i}
                        <Table_Row>
                            <Table_Col center aligned>
                                {col}
                            </Table_Col>
                            <Table_Col center aligned>
                                <Field>
                                    {#if (format[col].input === "text" || format[col].input === "number") && row[col] !== undefined}
                                        <!-- {format[col].capitalise ? row[col].toUpperCase() : row[col]} -->
                                        <Input ui type={format[col].input} bind:value={row[col]} on:keydown={handleKeydown}/>
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
                                        <Select ui dropdown bind:value={row[col]}>
                                            {#each typeDropdown(format[col].type) as item}
                                                <Option value={Object.keys(item)[0]}>{item[Object.keys(item)[0]]}</Option>
                                            {/each}
                                        </Select>
                                    {:else}
                                        ---
                                    {/if}
                                </Field>
                            </Table_Col>
                        </Table_Row>
                    {/each}
                </Table_Body>
            </Table>
        </Form>
        {#if errorMessage!==""}
            <Message ui error>{errorMessage}</Message>
        {/if}
    </Content>
    <Actions>
        <Button ui red on:click={()=>{closeLogin();}}>Cancel</Button>
        <Button ui green on:click={()=>{handleSubmit();}}>Log in</Button>
    </Actions>
</Modal>
