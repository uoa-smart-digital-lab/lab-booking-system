import React, { useState } from 'react';
import 'semantic-ui-css/semantic.min.css';

import { Form, Divider, Grid, Button, Modal, Header } from 'semantic-ui-react';
import GraphQL from './graphql';
import {
    ApolloProvider,
    useMutation,
	gql
  } from "@apollo/client";



// ----------------------------------------------------------------------------------------------------
// Do the login view
// ----------------------------------------------------------------------------------------------------
function View(args)
{
	// Set props and state
	const props = args.props;

	const MUTATION = gql`mutation login($upi: String!, $password: String!) { login (upi: $upi, password: $password) { sessionid upi } }`
	
	const [state, setState] = useState({
		upi: "",
		password: "",
		set: (name, value) => { setState( previousState => { return { ...previousState, [name]: value }} ); }
	});

	// The GraphQL function being used here
	const [login] = useMutation(MUTATION);

	// Do the actual login when the user presses the button
	let DoLogin = () =>
	{		
		login({variables: { upi: state.upi, password: state.password}})
		.then(result => props.loggedin(result.data.login))
		.catch(error => props.error(error))
	};

	// Hand the keypresses and changes in the UI
	let handleKeyPress = (e) => { if (e.charCode === 13) { DoLogin(); } }
	let handleChange = (e, { name, value }) => { state.set([name], value); };

	// The main UI
	return (
		<Modal open={true} size='tiny' >
			<Modal.Content>
			<Header as='h4' textAlign='center'>
				<span>LabBookings WebApp.</span><br/><span>Please log in.</span><br/>
				<span>{props.errorMessage}</span>
			</Header>
			<Divider />
			<Grid columns='one'>
				<Grid.Row>
				<Grid.Column>
					<Form>
					<Form.Field>
						<Form.Input placeholder="UPI" name="upi" type="text" value={state.upi} onKeyPress={handleKeyPress} onChange={handleChange}/>
					</Form.Field>
					<Form.Field>
						<Form.Input placeholder="Password" name="password" type="password" value={state.password} onKeyPress={handleKeyPress} onChange={handleChange}/>
					</Form.Field>
					</Form>
				</Grid.Column>
				</Grid.Row>
			</Grid>
			</Modal.Content>
			<Modal.Actions style={{ paddingLeft: '1.5em', paddingRight: '1.5em' }}>
			<Grid columns='one'>
				<Grid.Row>
				<Grid.Column>
					<Button fluid basic color='green' onClick={DoLogin}>Log in</Button>
				</Grid.Column>
				</Grid.Row>
			</Grid>
			</Modal.Actions>
		</Modal>
	)
}
// ----------------------------------------------------------------------------------------------------



// ----------------------------------------------------------------------------------------------------
// Main Function
// ----------------------------------------------------------------------------------------------------
export default function Login(props) { return (<ApolloProvider client={GraphQL.client}> <View props={props} /> </ApolloProvider>); }
// ----------------------------------------------------------------------------------------------------