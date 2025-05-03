<#
    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER Credential
        If the Online Responder service is configured to use Standalone certification authority,
        then an account that is a member of the local Administrators on the CA is required. If
        the Online Responder service is configured to use an Enterprise CA, then an account that
        is a member of Domain Admins is required.

    .PARAMETER Ensure
        Specifies whether the WS-Man Listener should exist.

    .PARAMETER Reasons
        Returns the reason a property is not in desired state.
#>

[DscResource()]
class AdcsOnlineResponder : ResourceBase
{
    [DscProperty(Key)]
    [ValidateSet('Yes')]
    [System.String]
    $IsSingleInstance

    [DscProperty(Mandatory)]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential

    [DscProperty(Mandatory)]
    [Ensure]
    $Ensure

    [DscProperty(NotConfigurable)]
    [AdcsReason[]]
    $Reasons

    AdcsOnlineResponder () : base ($PSScriptRoot)
    {
        # These properties will not be enforced.
        $this.ExcludeDscProperties = @(
            'Credential'
        )
    }

    [AdcsOnlineResponder] Get()
    {
        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get()
    }

    # Base method Get() call this method to get the current state as a Hashtable.
    [System.Collections.Hashtable] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        $state = @{
            IsSingleInstance = 'Yes'
            Ensure = 'Absent'
        }

        $service = Get-Service -Name 'OnlineResponder'

        if ($service) {
            $state.Ensure = 'Present'
        }

        return $state
    }

    [void] Set()
    {
        # Call the base method to enforce the properties.
        ([ResourceBase] $this).Set()
    }

    <#
        Base method Set() call this method with the properties that should be
        enforced and that are not in desired state.
    #>
    hidden [void] Modify([System.Collections.Hashtable] $properties)
    {
        $errorMessage = ''

        if ($this.Ensure -eq 'Present')
        {
            Write-Verbose -Message ($script:localizedData.InstallingAdcsOnlineResponderMessage)


            $errorMessage = (Install-AdcsOnlineResponder -Credential $this.Credential -Force).ErrorString
        }
        else
        {
            Write-Verbose -Message $script:localizedData.UninstallingAdcsOnlineResponderMessage

            $errorMessage = (Uninstall-AdcsOnlineResponder -Force).ErrorString
        }

        if (-not [System.String]::IsNullOrEmpty($errorMessage))
        {
            New-InvalidOperationException -Message $errorMessage
        }
    }

    [System.Boolean] Test()
    {
        # Call the base method to test all of the properties that should be enforced.
        return ([ResourceBase] $this).Test()
    }

    <#
        Base method Assert() call this method with the properties that was assigned
        a value.
    #>
    hidden [void] AssertProperties([System.Collections.Hashtable] $properties)
    {

    }

    <#
        Base method Normalize() call this method with the properties that was assigned
        a value.
    #>
    hidden [void] NormalizeProperties([System.Collections.Hashtable] $properties)
    {

    }
}
