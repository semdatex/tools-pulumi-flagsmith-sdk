import * as pulumi from "@pulumi/pulumi";
export declare class MvFeatureOption extends pulumi.CustomResource {
    /**
     * Get an existing MvFeatureOption resource's state with the given name, ID, and optional extra
     * properties used to qualify the lookup.
     *
     * @param name The _unique_ name of the resulting resource.
     * @param id The _unique_ provider ID of the resource to lookup.
     * @param state Any extra arguments used during the lookup.
     * @param opts Optional settings to control the behavior of the CustomResource.
     */
    static get(name: string, id: pulumi.Input<pulumi.ID>, state?: MvFeatureOptionState, opts?: pulumi.CustomResourceOptions): MvFeatureOption;
    /**
     * Returns true if the given object is an instance of MvFeatureOption.  This is designed to work even
     * when multiple copies of the Pulumi SDK have been loaded into the same process.
     */
    static isInstance(obj: any): obj is MvFeatureOption;
    /**
     * Boolean value of the multivariate option if the type is <span pulumi-lang-nodejs="`bool`" pulumi-lang-dotnet="`Bool`" pulumi-lang-go="`bool`" pulumi-lang-python="`bool`" pulumi-lang-yaml="`bool`" pulumi-lang-java="`bool`" pulumi-lang-hcl="`bool`">`bool`</span>
     */
    readonly booleanValue: pulumi.Output<boolean | undefined>;
    /**
     * Percentage allocation of the current multivariate option
     */
    readonly defaultPercentageAllocation: pulumi.Output<number>;
    /**
     * ID of the feature to which the multivariate option belongs
     */
    readonly featureId: pulumi.Output<number>;
    /**
     * UUID of the feature to which the multivariate option belongs
     */
    readonly featureUuid: pulumi.Output<string>;
    /**
     * Integer value of the multivariate option if the type is <span pulumi-lang-nodejs="`int`" pulumi-lang-dotnet="`Int`" pulumi-lang-go="`int`" pulumi-lang-python="`int`" pulumi-lang-yaml="`int`" pulumi-lang-java="`int`" pulumi-lang-hcl="`int`">`int`</span>
     */
    readonly integerValue: pulumi.Output<number | undefined>;
    /**
     * ID of the multivariate option
     */
    readonly mvFeatureOptionId: pulumi.Output<number>;
    /**
     * Project ID of the feature to which the multivariate option belongs
     */
    readonly projectId: pulumi.Output<number>;
    /**
     * String value of the multivariate option if the type is <span pulumi-lang-nodejs="`unicode`" pulumi-lang-dotnet="`Unicode`" pulumi-lang-go="`unicode`" pulumi-lang-python="`unicode`" pulumi-lang-yaml="`unicode`" pulumi-lang-java="`unicode`" pulumi-lang-hcl="`unicode`">`unicode`</span>
     */
    readonly stringValue: pulumi.Output<string | undefined>;
    /**
     * Type of the multivariate option can be <span pulumi-lang-nodejs="`unicode`" pulumi-lang-dotnet="`Unicode`" pulumi-lang-go="`unicode`" pulumi-lang-python="`unicode`" pulumi-lang-yaml="`unicode`" pulumi-lang-java="`unicode`" pulumi-lang-hcl="`unicode`">`unicode`</span>, <span pulumi-lang-nodejs="`int`" pulumi-lang-dotnet="`Int`" pulumi-lang-go="`int`" pulumi-lang-python="`int`" pulumi-lang-yaml="`int`" pulumi-lang-java="`int`" pulumi-lang-hcl="`int`">`int`</span> or <span pulumi-lang-nodejs="`bool`" pulumi-lang-dotnet="`Bool`" pulumi-lang-go="`bool`" pulumi-lang-python="`bool`" pulumi-lang-yaml="`bool`" pulumi-lang-java="`bool`" pulumi-lang-hcl="`bool`">`bool`</span>
     */
    readonly type: pulumi.Output<string>;
    /**
     * UUID of the multivariate option
     */
    readonly uuid: pulumi.Output<string>;
    /**
     * Create a MvFeatureOption resource with the given unique name, arguments, and options.
     *
     * @param name The _unique_ name of the resource.
     * @param args The arguments to use to populate this resource's properties.
     * @param opts A bag of options that control this resource's behavior.
     */
    constructor(name: string, args: MvFeatureOptionArgs, opts?: pulumi.CustomResourceOptions);
}
/**
 * Input properties used for looking up and filtering MvFeatureOption resources.
 */
export interface MvFeatureOptionState {
    /**
     * Boolean value of the multivariate option if the type is <span pulumi-lang-nodejs="`bool`" pulumi-lang-dotnet="`Bool`" pulumi-lang-go="`bool`" pulumi-lang-python="`bool`" pulumi-lang-yaml="`bool`" pulumi-lang-java="`bool`" pulumi-lang-hcl="`bool`">`bool`</span>
     */
    booleanValue?: pulumi.Input<boolean | undefined>;
    /**
     * Percentage allocation of the current multivariate option
     */
    defaultPercentageAllocation?: pulumi.Input<number | undefined>;
    /**
     * ID of the feature to which the multivariate option belongs
     */
    featureId?: pulumi.Input<number | undefined>;
    /**
     * UUID of the feature to which the multivariate option belongs
     */
    featureUuid?: pulumi.Input<string | undefined>;
    /**
     * Integer value of the multivariate option if the type is <span pulumi-lang-nodejs="`int`" pulumi-lang-dotnet="`Int`" pulumi-lang-go="`int`" pulumi-lang-python="`int`" pulumi-lang-yaml="`int`" pulumi-lang-java="`int`" pulumi-lang-hcl="`int`">`int`</span>
     */
    integerValue?: pulumi.Input<number | undefined>;
    /**
     * ID of the multivariate option
     */
    mvFeatureOptionId?: pulumi.Input<number | undefined>;
    /**
     * Project ID of the feature to which the multivariate option belongs
     */
    projectId?: pulumi.Input<number | undefined>;
    /**
     * String value of the multivariate option if the type is <span pulumi-lang-nodejs="`unicode`" pulumi-lang-dotnet="`Unicode`" pulumi-lang-go="`unicode`" pulumi-lang-python="`unicode`" pulumi-lang-yaml="`unicode`" pulumi-lang-java="`unicode`" pulumi-lang-hcl="`unicode`">`unicode`</span>
     */
    stringValue?: pulumi.Input<string | undefined>;
    /**
     * Type of the multivariate option can be <span pulumi-lang-nodejs="`unicode`" pulumi-lang-dotnet="`Unicode`" pulumi-lang-go="`unicode`" pulumi-lang-python="`unicode`" pulumi-lang-yaml="`unicode`" pulumi-lang-java="`unicode`" pulumi-lang-hcl="`unicode`">`unicode`</span>, <span pulumi-lang-nodejs="`int`" pulumi-lang-dotnet="`Int`" pulumi-lang-go="`int`" pulumi-lang-python="`int`" pulumi-lang-yaml="`int`" pulumi-lang-java="`int`" pulumi-lang-hcl="`int`">`int`</span> or <span pulumi-lang-nodejs="`bool`" pulumi-lang-dotnet="`Bool`" pulumi-lang-go="`bool`" pulumi-lang-python="`bool`" pulumi-lang-yaml="`bool`" pulumi-lang-java="`bool`" pulumi-lang-hcl="`bool`">`bool`</span>
     */
    type?: pulumi.Input<string | undefined>;
    /**
     * UUID of the multivariate option
     */
    uuid?: pulumi.Input<string | undefined>;
}
/**
 * The set of arguments for constructing a MvFeatureOption resource.
 */
export interface MvFeatureOptionArgs {
    /**
     * Boolean value of the multivariate option if the type is <span pulumi-lang-nodejs="`bool`" pulumi-lang-dotnet="`Bool`" pulumi-lang-go="`bool`" pulumi-lang-python="`bool`" pulumi-lang-yaml="`bool`" pulumi-lang-java="`bool`" pulumi-lang-hcl="`bool`">`bool`</span>
     */
    booleanValue?: pulumi.Input<boolean | undefined>;
    /**
     * Percentage allocation of the current multivariate option
     */
    defaultPercentageAllocation: pulumi.Input<number>;
    /**
     * UUID of the feature to which the multivariate option belongs
     */
    featureUuid: pulumi.Input<string>;
    /**
     * Integer value of the multivariate option if the type is <span pulumi-lang-nodejs="`int`" pulumi-lang-dotnet="`Int`" pulumi-lang-go="`int`" pulumi-lang-python="`int`" pulumi-lang-yaml="`int`" pulumi-lang-java="`int`" pulumi-lang-hcl="`int`">`int`</span>
     */
    integerValue?: pulumi.Input<number | undefined>;
    /**
     * String value of the multivariate option if the type is <span pulumi-lang-nodejs="`unicode`" pulumi-lang-dotnet="`Unicode`" pulumi-lang-go="`unicode`" pulumi-lang-python="`unicode`" pulumi-lang-yaml="`unicode`" pulumi-lang-java="`unicode`" pulumi-lang-hcl="`unicode`">`unicode`</span>
     */
    stringValue?: pulumi.Input<string | undefined>;
    /**
     * Type of the multivariate option can be <span pulumi-lang-nodejs="`unicode`" pulumi-lang-dotnet="`Unicode`" pulumi-lang-go="`unicode`" pulumi-lang-python="`unicode`" pulumi-lang-yaml="`unicode`" pulumi-lang-java="`unicode`" pulumi-lang-hcl="`unicode`">`unicode`</span>, <span pulumi-lang-nodejs="`int`" pulumi-lang-dotnet="`Int`" pulumi-lang-go="`int`" pulumi-lang-python="`int`" pulumi-lang-yaml="`int`" pulumi-lang-java="`int`" pulumi-lang-hcl="`int`">`int`</span> or <span pulumi-lang-nodejs="`bool`" pulumi-lang-dotnet="`Bool`" pulumi-lang-go="`bool`" pulumi-lang-python="`bool`" pulumi-lang-yaml="`bool`" pulumi-lang-java="`bool`" pulumi-lang-hcl="`bool`">`bool`</span>
     */
    type: pulumi.Input<string>;
}
//# sourceMappingURL=mvFeatureOption.d.ts.map