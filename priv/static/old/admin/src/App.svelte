<script lang="ts">
    
    import { behavior, Grid, Modal, Column, Row, Button, Dropdown, Input, Icon, Text, Menu, Item, Link } from 'svelte-fomantic-ui';

    import { ApolloClient, InMemoryCache } from '@apollo/client';
    import { setClient } from 'svelte-apollo';

    import { onMount } from 'svelte';

    import type { Person } from "./lib/Graphql.svelte";

    import Login from './lib/Login.svelte';
    import MainGraphic from './lib/MainGraphic.svelte';
    import ItemsTable from './lib/ItemsTable.svelte';

    let sessionid: string = "";
    let user: Person;
    let searchString: string = "";

    onMount(() => {
        behavior("login_dialog", "show");
    })


    // -------------------------------------------------------------------------------------------------
    // GraphQL
    // -------------------------------------------------------------------------------------------------
    // GraphQL client setup 
    const client = new ApolloClient({
        uri:  '/api',
        cache: new InMemoryCache()
    });
    setClient(client);
    // -------------------------------------------------------------------------------------------------



    // -------------------------------------------------------------------------------------------------
    // Check the result of the login
    // -------------------------------------------------------------------------------------------------
    function loggedIn(event: {detail: {message: string, data: {person:Person, sessionid: string}}}) {
        switch (event.detail.message) {
            case "success":
                user = event.detail.data.person;
                sessionid = event.detail.data.sessionid;
                behavior("login_dialog", "hide");
                break;
            case "close":
                behavior("login_dialog", "hide");
                break;

            default: break;
        }
    }
    // -------------------------------------------------------------------------------------------------



    // -------------------------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------------------------
    function login() {
        behavior("login_dialog", "show");
    }
    // -------------------------------------------------------------------------------------------------



    // -------------------------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------------------------
    function logout(event: {data: Object, message: string}) {
        user = undefined;
        sessionid = "";
    }
    // -------------------------------------------------------------------------------------------------



</script>



<main>
    <MainGraphic {sessionid} {user}/>

    <Menu ui three fluid item attached top>
        <Link item>
            <Input ui transparent icon>
                <Input prompt type="text" placeholder="Refine..." bind:value={searchString}/>
                <Icon search link/>
            </Input>
        </Link>
        <Dropdown ui item>
            <Link ui icon>
                <Icon dropdown/>
                <Text default>Select...</Text>
            </Link>
            <Menu ui>
                <Item centered value="Items">Items</Item>
                <Item centered value="People">People</Item>
            </Menu>
        </Dropdown>
        {#if sessionid===""}
            <Item link on:click={login}>
                <Icon ui sign in alternative/>
                login
            </Item>
        {:else}
            <Item link on:click={logout}>
                <Icon ui sign out alternative/>
                logout
            </Item>
        {/if}
    </Menu>

    <ItemsTable {searchString} loggedIn={sessionid !== ""} {sessionid} />

    <Modal ui tiny id="login_dialog">
        <Login on:login={loggedIn}/>
    </Modal>
</main>



<style>

</style>
