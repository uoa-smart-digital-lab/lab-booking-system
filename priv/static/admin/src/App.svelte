<script lang="ts">
    import {reload} from "svelte-fomantic-ui";
    import GraphQL_Table from "./lib/GraphQL_Table.svelte";
    import { GraphQL, Person, Item, Session } from "./lib/Graphql.svelte";
    import Login from "./lib/Login.svelte";
    import { afterUpdate } from "svelte";


    // let details: PersonDetails = new PersonDetails("123456789", "here@there");

    let thePeople: Array<Person> = [];
    let theItems: Array<Item> = [];

    let connection = new GraphQL("/api");
    let loading = true;
    let error = false;

    afterUpdate(() => { reload(); });

    let session: Session = new Session();
    session.login(connection, "rdav031", "12345")
    .then(() => {
        // Login successful
        console.log("Logged in :", session);

        Item.itemAll(connection, session)
        .then((items) => {
            theItems = items;
            Person.personAll(connection, session)
            .then((people) => {
                thePeople = people;
                loading = false;
            })
        })
        .catch((errorDetails) => {
            error = true;
            console.log(errorDetails);
        });
    })
    .catch((errorDetails) => {
        error = true
        console.log(errorDetails);
        // Login failed, handle error
    });

    function login (event : any) {
        // switch (event.detail.message)
        // {
        //     case 'close' : LoginC.step(LoginEvents.CLOSE_DIALOG); break;
        //     case 'success' : LoginC.step(LoginEvents.LOG_IN, event.detail.data); break;
        //     default: break;
        // }
    }

</script>

<main>

    <!-- <Login id="LoginDialog" on:login={login}/> -->

    {#if error}
        error ...
    {:else if loading}
        loading ...
    {:else}
        <GraphQL_Table definition="Person" id="people" data={thePeople}/>
        <GraphQL_Table definition="Item" id="items" data={theItems}/>
    {/if}
</main>

<style>

</style>
