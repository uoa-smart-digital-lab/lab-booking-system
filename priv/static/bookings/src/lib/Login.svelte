<script lang="ts">
    import {behavior, Modal, Icon, Header, Content, Image, Description, Actions, Button, Form, Field, Label, Input} from "svelte-fomantic-ui";
    export let id: string="Login_Dialog";
</script>


<Modal ui tiny {id}>
    <Content>
        <Form ui>
            <Image ui src="/images/logo.png"/>
            <Field>
                <Label input>User name</Label>
                <Input text placeholder="User name"/>
            </Field>
            <Field>
                <Label input>Password</Label>
                <Input password placeholder="Password"/>
            </Field>
        </Form>
    </Content>
    <Actions>
        <Button ui red on:click={()=>{behavior(id, "hide")}}>Cancel</Button>
        <Button ui green on:click={()=>{behavior(id, "hide")}}>Log in</Button>
    </Actions>
</Modal>