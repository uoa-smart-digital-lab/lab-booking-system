import { Component } from 'react';
import 'semantic-ui-css/semantic.min.css';
import { Card, Icon, Header } from 'semantic-ui-react'
import GraphQL from './graphql';


// ----------------------------------------------------------------------------------------------------
// Show the error returned from GraphQL
// ----------------------------------------------------------------------------------------------------
class Error extends Component
{
    constructor(props) {
        super (props);

        this.state = {
            message: GraphQL.errorcodes[this.props.message]
        }
    }
    render ()
    {
        return (
            <>
                <Header centered as="h3" color='red' block>
                    Error
                </Header>
                <Card.Group centered>
                    <Card color='red'>
                        <Card.Content>
                            <Icon color='red' name='exclamation circle' size='massive'/>
                        </Card.Content>
                        <Card.Content>
                            <Card.Header as="h3">{this.state.message}</Card.Header>
                        </Card.Content>
                    </Card>
                </Card.Group>
            </>
        )
    }
}

export default Error;
// ----------------------------------------------------------------------------------------------------
