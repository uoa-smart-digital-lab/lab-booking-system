import { Component } from 'react';
import 'semantic-ui-css/semantic.min.css';
import { Card, Dimmer, Loader } from 'semantic-ui-react'


// ----------------------------------------------------------------------------------------------------
// Show a loading symbol for when the data is being loaded from the database
// ----------------------------------------------------------------------------------------------------
class Loading extends Component
{
    constructor(props) {
        super (props);
    }
    render ()
    {
        return (
            <>
                <br />
                <Card.Group centered>
                    <Card color="blue">
                        {/* <Card.Content>
                            <Icon color="blue" name='hourglass outline' size='massive'/>
                        </Card.Content> */}
                        <Dimmer active inverted>
                            <Loader inverted>Loading</Loader>
                        </Dimmer>
                    </Card>
                </Card.Group>
            </>
        )
    }
}

export default Loading;
// ----------------------------------------------------------------------------------------------------
